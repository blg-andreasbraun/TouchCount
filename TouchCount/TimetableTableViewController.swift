//
//  TimetableTableViewController.swift
//  TouchCount
//
//  Created by Andreas Braun on 23.01.17.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import UIKit
import CoreData

class TimetableTableViewController: UITableViewController {

    // MARK: - Instance variables
    var fetchedResultsController: NSFetchedResultsController<TimeEntry>? {
        didSet {
            self.setUpFetchedResultsController()
        }
    }
    
    // MARK: - Fetching
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let fetchRequest: NSFetchRequest<TimeEntry> = TimeEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = fetchedResultsController?.sections?.count else { return 0 }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections, sections.count > 0 else { return 0 }
        
        return sections[section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)

        let entry = fetchedResultsController!.object(at: indexPath)
        
        let name = entry.name ?? "N/A"
        
        cell.textLabel?.text = "\(name) (\(DateFormatter.localizedString(from: entry.date! as Date, dateStyle: .short, timeStyle: .short)))"
        cell.detailTextLabel?.text = NSLocalizedString("Duration:", comment: "") + " \(timeString(from: TimeInterval(entry.duration))) " + NSLocalizedString("Count:", comment: "") + " \(entry.count)"
        
        return cell
    }

    
    // MARK: - Private
    
    private func setUpFetchedResultsController() {
        self.fetchedResultsController!.delegate = self
        self.performFetch()
    }

}

extension TimetableTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        case .update:
            break
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

}
