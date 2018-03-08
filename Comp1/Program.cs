using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Comp1
{
    class Program
    {
        //This is our connection string. Replace with your own.
        private static string _conString = "Data Source=.\\SQLEXPRESS;" +
                                           "Initial Catalog=Company;" +
                                           "Integrated Security=true;";

        static void Main(string[] args)
        {
            //GetDepartments with employee count
            var departments = GetDepartments();
            var department = GetDepartment(5);
        }

        static Department GetDepartment(int id)
        {
            using (var conn = new SqlConnection(_conString))
            {
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_GetDepartment";
                    cmd.CommandType = CommandType.StoredProcedure;

                    var p = cmd.Parameters.AddWithValue("DNumber", id);

                    Department item = null;

                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            item = new Department();
                            item.Id = reader.GetInt32(1);
                            item.Name = reader.GetString(0);
                            item.ManagerSSN = reader.GetDecimal(2);
                            item.ManagerStartDate = reader.GetDateTime(3);
                            item.EmployeeCount = reader.GetInt32(4);

                        }
                    }
                    return item;
                }
            }
        }

        static IList<Department> GetDepartments()
        {
            List<Department> list = new List<Department>();
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
                            var item = new Department();
                            item.Id = reader.GetInt32(1);
                            item.Name = reader.GetString(0);
                            item.ManagerSSN = reader.GetDecimal(2);
                            item.ManagerStartDate = reader.GetDateTime(3);
                            item.EmployeeCount = reader.GetInt32(4);
                            list.Add(item);
                        }
                    }
                }
            }
            return list;
        }
    }
}
