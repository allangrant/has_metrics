module Metrics
  def self.included(base)
    base.extend ClassMethods

    klass_name = "#{base}Metrics"
    klass = begin
      Object.const_get(klass_name)
    rescue
      Object.const_set(klass_name, Class.new(ActiveRecord::Base))
    end
    klass.class_eval do
      extend Metrics::MetricsClass
      belongs_to base.to_s.underscore.to_sym, :foreign_key => 'id'
      @object_class = base
    end

    base.class_eval do
      if klass.table_exists?
        @metrics_class = klass
        has_one :metrics, :class_name => klass_name, :foreign_key => 'id', :dependent => :destroy
      else
        @object_class = base
        @metrics_class = base
        base.extend(Metrics::MetricsClass)
      end

      def metrics
        @metrics ||= self.class.metrics_class.find_or_create_by_id(id)
      end
    end
  end

  module ClassMethods
    # CLASS METHODS ADDED
    def metrics_class
      @metrics_class
    end
    def has_metric name, options={}, &block
      define_method name do |*args|
        frequency = options[:every] || 20.hours
        previous_result = metrics.attributes[name.to_s] unless options[:every] == :always
        datestamp_column = "updated__#{name}__at"
        datestamp = metrics.attributes[datestamp_column]
        force = [:force, true].include?(args[0])
        case
        when !force && previous_result && options[:once]
          # Only calculate this metric once.  If it's not nil, reuse the old value.
          previous_result
        when !force && frequency.is_a?(Fixnum) && datestamp && datestamp > frequency.ago
          # The metric was recently calculated and can be reused.
          previous_result
        else
          result = instance_exec(&block)
          result = nil if result.is_a?(Float) && !result.finite?
          begin
            metrics.send "#{name}=", result
            metrics.send "#{datestamp_column}=", Time.current
          rescue NoMethodError => e
            raise e unless e.name == "#{name}=".to_sym
            # This happens if the migrations haven't run yet for this metric. We should still calculate & return the metric.
          end
          unless changed?
            metrics.save
          end
          result
        end
      end

      (@metrics ||= []) << name.to_sym
      @metrics.uniq!

      if respond_to?(:has_custom_order_by)  # TODO: carve out has_custom_order_by functionality into this gem
        unless metrics_class == self
          has_custom_order_by name do |column, order|
            { :joins => :metrics, :order => "#{reflect_on_association(:metrics).table_name}.#{column} #{order}" }
          end
        end
      end

      if options[:type] && (options[:type].to_sym == :float)
        (@float_metrics ||= []) << name.to_sym
      end
    end

    def metrics
      @metrics
    end

    def metrics_column_type(column)
      case
      when (column.to_s =~ /^by_(.+)$/) && respond_to?(:segment_categories) && segment_categories.include?($1.to_sym) # TODO: carve out segementation functionality into this gem
        :string
      when (column.to_s =~ /_at$/)
        :datetime
      when @float_metrics && @float_metrics.include?(column.to_sym)
        :float
      else
        :integer
      end
    end

    def update_all_metrics!(*args)
      metrics_class.migrate!
      # start_time = Time.zone.now
      # total = all.count
      # if caller.find {|c| c =~ /irb_binding/} # When called from irb
      #   puts "Updating all metrics on #{name}: #{metrics.join(', ')}"
      #   puts "Updating #{total} records."
      #   progress_bar = ProgressBar.new("Progress", total)
      # end
      find_in_batches do |batch|
        metrics_class.transaction do
          batch.each do |record|
            # puts "Updating record ##{record.id}: #{record}"
            record.update_metrics!(*args)
          end
        end
        # progress_bar.inc if progress_bar
      end
      # progress_bar.finish if progress_bar
      # elapsed = Time.zone.now - start_time
      # Notifier.deliver_simple_message('allan@curebit.com', '[CUREBIT] Metrics computation time', "Finished calculating #{metrics.count} metrics on #{total} #{name.underscore.humanize.downcase.pluralize} in #{elapsed/60} minutes (#{elapsed/total} sec per entry) (#{elapsed/(total*metrics.count)} sec per metric). \n\nMetrics calculated:\n\n#{metrics.join("\n")}")
      metrics
    end
  end
  ### END CLASS METHODS, START INSTANCE METHODS

  def update_metrics!(*args)
    self.class.metrics.each do |metric|
      send(metric, *args)
    end
  end
  ### END INSTANCE METHODS

  ### Sets up a class like "SiteMetrics".  These are all CLASS methods:
  module MetricsClass
    def object_class
      @object_class
    end

    def metrics_updated_at_columns
      @object_class.metrics.map{|metric| "updated__#{metric}__at"}
    end

    def required_columns
      @object_class.metrics.map(&:to_s) + metrics_updated_at_columns
    end

    def missing_columns
      reset_column_information
      required_columns - (columns.map(&:name) - %w(id created_at updated_at))
    end

    def extra_columns
      reset_column_information
      if @object_class == self
        raise "Cannot determine if there were extra columns for has_metric when using the table itself for storing the metric!  Remove any columns manually"
        [] # We wont know what columns are excessive if the source changed
      else
        (columns.map(&:name) - %w(id created_at updated_at)) - required_columns
      end

    end

    class Metrics::Migration < ActiveRecord::Migration
      def self.setup(metrics)
        @metrics = metrics
      end
      def self.up
        @metrics.missing_columns.each do |column|
          column_type = @metrics.object_class.metrics_column_type(column)
          add_column @metrics.table_name, column, column_type, (column_type==:string ? {:null => false, :default => ''} : {})
        end
      end
      def self.down
        @metrics.extra_columns.each do |column|
          remove_column @metrics.table_name, column
        end
      end
    end

    def remigrate!
      old_metrics = @object_class.metrics
      @object_class.class_eval { @metrics = [] }
      migrate!
      @object_class.class_eval { @metrics = old_metrics }
      migrate!
    end

    def migrate!
      # don't migrate if metrics are kept in current class
      return if @object_class == self

      Metrics::Migration.setup(self)
      Metrics::Migration.down unless extra_columns.empty?
      Metrics::Migration.up unless missing_columns.empty?
      reset_column_information
    end
  end
end
