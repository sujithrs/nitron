module Nitron
  module Data
    class Model < NSManagedObject
      module Persistence
      
        def self.included(base)
          base.extend(ClassMethods)
        end
   
        module ClassMethods
        
          def create(attributes={})
            begin
              model = create!(attributes)
            rescue Nitron::RecordNotSaved
            end
            model
          end

          def create!(attributes={})
            model = new(attributes)
            model.save!
            model
          end

          def find_or_create(attributes={})
            model = self.where(attributes)  
            model.to_a.empty? ?  self.create(attributes) : model.first
          end
        
          def new(attributes={})
            alloc.initWithEntity(entity_description, insertIntoManagedObjectContext:nil).tap do |model|
              model.instance_variable_set('@new_record', true)
              attributes.each do |keyPath, value|
                model.setValue(value, forKey:keyPath)
              end
            end
          end
        
        end
      
        def destroy
        
          if context = managedObjectContext
            context.deleteObject(self)
            error = Pointer.new(:object)
            context.save(error)
          end
        
          @destroyed = true
          freeze
        end
      
        def destroyed?
          @destroyed || false
        end
      
        def new_record?
          @new_record || false
        end
      
        def persisted?
          !(new_record? || destroyed?)
        end
      
        def save
          begin
            save!
          rescue Nitron::RecordNotSaved
            return false
          end
          true
        end
      
        def save!        
          unless context = managedObjectContext
            context = UIApplication.sharedApplication.delegate.managedObjectContext
            context.insertObject(self)
          end

          error = Pointer.new(:object)
          unless context.save(error)
            managedObjectContext.deleteObject(self)
            raise Nitron::RecordNotSaved, self and return false
          end
          true
        end
      
        def update_attributes(attributes)
          attributes.each do |keyPath, value|
            self.setValue(value, forKey:keyPath)
          end
          self.save
        end
      end
    end
  end
end
