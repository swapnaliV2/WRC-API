using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace WRC_API.HelperClass
{
    public class SqlServer
    {
        private string _conStr = string.Empty;

        public SqlServer()
        {
            _conStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            if (string.IsNullOrEmpty(_conStr))
                throw new ArgumentNullException("Provided Connection string is not present in Connection String Section of Config");
        }
       

        public void ExecuteDataNQ(string command, Dictionary<string, object> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            innerWatch.Start();

            using (SqlConnection connection = new SqlConnection(_conStr))
            {
                try
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Open();

                    using (SqlCommand sqlCommand = new SqlCommand(command, connection))
                    {
                        sqlCommand.CommandType = commandType;
                        foreach (var param in parameters)
                        {
                            sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                        }
                        sqlCommand.ExecuteNonQueryAsync();
                        innerWatch.Stop();
                        AppLogger.LogTimer(innerWatch);
                    }
                }
                catch (Exception ex)
                {
                    innerWatch.Stop();
                    AppLogger.LogError(ex);
                }
                finally
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Close();
                    innerWatch.Stop();
                }
            }

        }

        public async Task<DataSet> ExecuteData(string command, Dictionary<string, object> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            DataTable dtData = new DataTable();
            DataSet dsData = new DataSet();
            innerWatch.Start();
            using (SqlConnection connection = new SqlConnection(_conStr))
            {
                try
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Open();

                    using (SqlCommand sqlCommand = new SqlCommand(command, connection))
                    {
                        sqlCommand.CommandType = commandType;
                        foreach (var param in parameters)
                        {
                            sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                        }

                        //SqlDataReader dr = await sqlCommand.ExecuteReaderAsync();
                        //dtData.Load(dr);
                        SqlDataAdapter dr =new SqlDataAdapter(sqlCommand);                        
                        dr.Fill(dsData);
                        innerWatch.Stop();
                        AppLogger.LogTimer(innerWatch);
                    }
                }
                catch (Exception ex)
                {
                    innerWatch.Stop();
                    AppLogger.LogError(ex);
                    // return 1;
                }
                finally
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Close();
                    innerWatch.Stop();
                }
                //return dtData;
                return dsData;
            }
        }
    }
}