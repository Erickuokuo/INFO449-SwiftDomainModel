import Foundation
struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
struct Money {
    let amount: Int
    let currency: String
    
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    func convert(_ targetCurrency: String) -> Money {
        guard let exchangeRate = exchangeRate(from: currency, to: targetCurrency) else {
            return Money(amount: 0, currency: "")
        }
        
        let convertedAmount = Double(amount) * exchangeRate
        return Money(amount: Int(round(convertedAmount)), currency: targetCurrency)
    }
    
    func add(_ other: Money) -> Money {
        if currency == other.currency {
            let addedAmount = amount + other.amount
            return Money(amount: addedAmount, currency: currency)
        } else {
            let converted = self.convert(other.currency)
            let addedAmount = converted.amount + other.amount
            return Money(amount: addedAmount, currency: other.currency)
        }
    }

    func subtract(_ other: Money) -> Money {
        if currency == other.currency {
            let subbedAmount = amount - other.amount
            return Money(amount: subbedAmount, currency: currency)
        } else {
            let converted = self.convert(other.currency)
            let subbedAmount = converted.amount + other.amount
            return Money(amount: subbedAmount, currency: other.currency)
        }
    }
    
    private func exchangeRate(from sourceCurrency: String, to targetCurrency: String) -> Double? {
        switch (sourceCurrency, targetCurrency) {
        case ("USD", "GBP"):
            return 0.5
        case ("GBP", "USD"):
            return 2.0
        case ("USD", "EUR"):
            return 1.5
        case ("EUR", "USD"):
            return 1.0 / 1.5
        case ("USD", "CAN"):
            return 1.25
        case ("CAN", "USD"):
            return 1.0 / 1.25
        case (let source, let target) where source == target:
            return 1.0
        default:
            return nil
        }
    }
}
    

////////////////////////////////////
// Job
//
public class Job {
    
    public enum JobType {
        case Hourly(Double)
        case Salary(Int)
    }
    
    let title: String
    var type: JobType
        
        // Initializer
        init(title: String, type: JobType) {
            self.title = title
            self.type = type
        }
        
        // Method to calculate income
    func calculateIncome(_ hours : Int) -> Int {
            switch type {
            case .Hourly(let hourlyWage):
                return Int(hourlyWage) * hours
            case .Salary(let yearlySalary):
                return yearlySalary
            }
        }
        
        // Method to give raise by amount
    func raise(byAmount amount: Double) {
        switch type {
        case .Hourly(let hourlyWage):
            let newHourlyWage = hourlyWage + amount
            type = .Hourly(newHourlyWage)
        case .Salary(let yearlySalary):
            let newYearlySalary = yearlySalary + Int(amount)
            type = .Salary(newYearlySalary)
        }
        }
        
    // Method to give raise by percentage
    func raise(byPercent percentage: Double) {
        switch type {
        case .Hourly(let hourlyWage):
            let newHourlyWage = hourlyWage * (1 + percentage)
            type = .Hourly(newHourlyWage)
        case .Salary(let yearlySalary):
            let newYearlySalary = Int(Double(yearlySalary) * (1 + percentage))
            type = .Salary(newYearlySalary)
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    let firstName: String
    let lastName: String
    var job: Job? {
        didSet {
            if age < 16 {
                job = nil
            }
        }
    }
    
    var spouse: Person? {
        didSet {
            if age < 18 {
                spouse = nil
            }
        }
    }
    var age: Int
    
   init(firstName: String, lastName: String, age: Int) {
       self.firstName = firstName
       self.lastName = lastName
       self.age = age
   }
       

    
       func toString() -> String {
           var description = "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age)"
           if let job = job, age > 15 {
               description += " job:\(job)"
           } else {
               description += " job:nil"
           }
           if let spouse = spouse, age > 17 {
               description += " spouse:\(spouse.firstName)"
           } else {
               description += " spouse:nil"
           }
           description += "]"
           return description
       }
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person]

    init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil && spouse2.spouse == nil else {
            fatalError("Both spouses must not have a current spouse.")
        }
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        self.members = [spouse1, spouse2]
    }

    func haveChild(_ child: Person) -> Bool {
        // Check if at least one spouse is over the age of 21
        if members.contains(where: { $0.age >= 21 }) {
            // Add the child to the family members
            members.append(child)
            return true
        } else {
            // Family cannot have a child according to US law
            return false
        }
    }

    func householdIncome() -> Double {
        // Calculate the total income of the family
        var totalIncome: Double = 0
        for member in members {
            if let job = member.job {
                switch job.type {
                case .Hourly(let rate):
                    totalIncome += rate * 2000
                case .Salary(let amount):
                    totalIncome += Double(amount)
                }
            }
        }
        return totalIncome
    }
}
