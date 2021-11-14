
import UIKit
import CoreData

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var taskArray = [NSManagedObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.dataSource = self


    fetchDatasFromeCoreData()
  }


  @IBAction func addTask(_ sender: Any) {
    let alert = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
    let add = UIAlertAction(title: "add", style: .default) { [unowned self] action in
      guard let textField = alert.textFields?.first, let newText = textField.text else { return }
      self.saveDataToCoreData(newText)
    }
    let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)

    alert.addTextField { textfield in
      textfield.placeholder = "Enter new task"
    }
    alert.addAction(add)
    alert.addAction(cancel)

    present(alert, animated: true, completion: nil)
  }
  
  func fetchDatasFromeCoreData(){
    guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = delegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")

    do{
      taskArray = try context.fetch(fetchRequest)
      tableView.reloadData()
    }catch let error as NSError {
      print("Cant fetch request. \(error), \(error.userInfo)")
    }
  }
  
  func saveDataToCoreData(_ newTask: String){
    guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = delegate.persistentContainer.viewContext

    guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
    let task = NSManagedObject(entity: entity, insertInto: context)

    task.setValue(newTask, forKey: "taskName")
    do{
      try context.save()
      taskArray.append(task)
      tableView.reloadData()
    }catch let error as NSError {
      print("Cant save. \(error), \(error.userInfo)")
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = taskArray[indexPath.row].value(forKey: "taskName") as? String
    return cell
  }
}

