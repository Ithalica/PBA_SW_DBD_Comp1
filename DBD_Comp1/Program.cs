using DBD_Comp1.App_Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;

namespace DBD_Comp1
{
    class Program
    {
        //This is our connection string. Replace with your own.
        private static string _conString = "Data Source=.\\SQLEXPRESS;" +
                                           "Initial Catalog=Company;" +
                                           "Integrated Security=true;";

        static void Main(string[] args)
        {
            //_conString = System.Configuration.ConfigurationManager.ConnectionStrings["Model1Container"].ConnectionString;
            // ResetDatabase();


            //GetDepartments with employee count
            var departmentsWithEmployeeCount = GetDepartments();

            var department = GetDepartment(5);

        }
        
        static DepartmentWithSlaveCount GetDepartment(int id)
        {
            using (var conn = new SqlConnection(_conString))
            {
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_GetDepartment";
                    cmd.CommandType = CommandType.StoredProcedure;

                    var p = cmd.Parameters.AddWithValue("DNumber", id);

                    DepartmentWithSlaveCount item = null;

                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            item = new DepartmentWithSlaveCount();
                            item.Id = reader.GetInt32(1);
                            item.Name = reader.GetString(0);
                            item.ManagerSSN = reader.GetDecimal(2);
                            item.ManagerStartDate = reader.GetDateTime(3);
                            item.SlaveCount = reader.GetInt32(4);

                        }
                    }
                    return item;
                }
            }
        }
        static IList<DepartmentWithSlaveCount> GetDepartments()
        {
            List<DepartmentWithSlaveCount> list = new List<DepartmentWithSlaveCount>();
            using (var conn = new SqlConnection(_conString))
            {
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_GetAllDepartments";
                    cmd.CommandType = CommandType.StoredProcedure;

                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            var item = new DepartmentWithSlaveCount();
                            item.Id = reader.GetInt32(1);
                            item.Name = reader.GetString(0);
                            item.ManagerSSN = reader.GetDecimal(2);
                            item.ManagerStartDate = reader.GetDateTime(3);
                            item.SlaveCount = reader.GetInt32(4);
                            list.Add(item);
                        }
                    }
                }
            }
            return list;
        }
    }

    class Department
    {

        public string Name { get; set; }
        public int Id { get; set; }
        public decimal ManagerSSN { get; set; }
        public DateTime ManagerStartDate { get; set; }
    }

    class DepartmentWithSlaveCount : Department
    {
        public int SlaveCount { get; set; }
    }
}
