module Nitron
  class TableViewController < ViewController
    include CoreDataSource
    attr_accessor :frc

    def self.collection(&block)
      options[:collection] = block
    end

    def self.group_by(name, opts={})
      options[:groupBy] = name.to_s
      options[:groupIndex] = opts[:index] || false
    end

    def self.options
      @options ||= {
        collection: lambda { [] },
        groupBy:    nil,
        groupIndex: false,
      }
    end
    
    # The idea behind this is that it should be possible to
    # replace the datasource and rely on Motion's GC to
    # clean up after us.
    #
    # This allows for code like:
    #
    #   def onFilterResults(searchText)
    #     reload { Task.where('name contains[ac] "foo"') }
    #   end
    #
    # This method is effective for filtering, but can
    # also be used for reordering as:
    #
    #    def onSortAlpha
    #      reload { Task.order('name[ac]') }
    #    end
    #
    def reload(reload = true, &block)
      self.class.options[:collection] = block
      load_frc
      view.reloadData if reload
    end

  protected

    def controllerDidChangeContent(controller)
      puts "controllerDidChangeContent"
      self.view.reloadData()
      _scroll_to_position
    end

    def collection
      self.instance_eval(&self.class.options[:collection])
    end

    def load_frc
      context = UIApplication.sharedApplication.delegate.managedObjectContext
      self.frc = NSFetchedResultsController.alloc.initWithFetchRequest(
        collection, managedObjectContext:context, sectionNameKeyPath:nil, 
        cacheName:nil)
      self.frc.delegate = self
      errorPtr = Pointer.new(:object)
      unless self.frc.performFetch(errorPtr)
        raise "Error fetching data"
      end
    end

    def prepareForSegue(segue, sender:sender)
      model = nil

      if view.respond_to?(:indexPathForSelectedRow)
        if view.indexPathForSelectedRow
          model = self.frc.objectAtIndexPath(view.indexPathForSelectedRow)
        end
      end

      if model
        controller = segue.destinationViewController
        if controller.respond_to?(:model=)
          controller.model = model
        end
      end
    end

    def viewDidLoad
      super
      load_frc
      _scroll_to_position
      #view.delegate = self
    end

    def _scroll_to_position
      return unless self.respond_to? :scroll_to_position
      position, animated = scroll_to_position
      lastSection = self.view.numberOfSections - 1
      return if lastSection < 0 

      lastRow = self.view.numberOfRowsInSection(lastSection) - 1
      return if lastRow < 0 
      ip = NSIndexPath.indexPathForRow(lastRow, inSection:lastSection)
      self.view.scrollToRowAtIndexPath(ip, 
          atScrollPosition:position, animated:animated)
    end

  end
end
