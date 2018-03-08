using System;

namespace Comp1
{
    class Department
    {

        public string Name { get; set; }
        public int Id { get; set; }
        public decimal ManagerSSN { get; set; }
        public DateTime ManagerStartDate { get; set; }
        public int EmployeeCount { get; internal set; }
    }
}
