module Nitron
  module CoreDataSource
    def numberOfSectionsInTableView(tableView)
      self.frc.sections.count
    end

    def objectAtIndexPath(indexPath)
      self.frc.objectAtIndexPath(indexPath)
    end

    def sectionForSectionIndexTitle(title, atIndex:index)
      self.frc.sectionForSectionIndexTitle(title, atIndex:index)
    end

    def tableView(tableView, numberOfRowsInSection:section)
      self.frc.sections.objectAtIndex(section).numberOfObjects
    end

    def tableView(tableView, titleForHeaderInSection:section)
      self.frc.sections[section].name
    end
  end
end