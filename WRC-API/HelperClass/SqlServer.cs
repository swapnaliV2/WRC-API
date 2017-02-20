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

        public void ExecuteDataNQ(string command, Dictionary<string, string> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            innerWatch.Start();

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();

            SqlConnection con = new SqlConnection(connectionString);
            using (SqlConnection connection = new SqlConnection(_conStr))
            {
                try
                {
                    if (con.State != ConnectionState.Open)
                        con.Open();

                    using (SqlCommand sqlCommand = new SqlCommand(command, con))
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
                    if (con.State != ConnectionState.Open)
                        con.Close();
                    innerWatch.Stop();
                }
            }
           
        }
        //public async Task ExecuteDataReader<T>(IDictionary<string, List<SqlParameter>> procList)
        //{
        //    SqlDataReader reader = null;
        //    KeyValuePair<string, T> kvp;
        //    using (SqlConnection connection = new SqlConnection(_conStr))
        //    {
        //        await connection.OpenAsync();
        //        if (connection.State != ConnectionState.Open)
        //            connection.Open();

        //        using (SqlCommand command = new SqlCommand(procName, connection))
        //        {
        //            command.CommandType = CommandType.StoredProcedure;

        //            if (paramList != null)
        //            {
        //                foreach (var param in paramList)
        //                    command.Parameters.Add(param);
        //            }
        //            Stopwatch watch = new Stopwatch();
        //            watch.Start();
        //            reader = await command.ExecuteReaderAsync();

        //            watch.Stop();
        //            _logger.Info(string.Format("{0} took {1} milliseconds", procName, watch.ElapsedMilliseconds));
        //            kvp = new KeyValuePair<string, T>(procName, output(reader));
        //        }
        //    }
        //}

        public async Task<Dictionary<string, T>> ExecuteDataReader<T>(IDictionary<string, List<SqlParameter>> procList, Func<SqlDataReader, T> output)
        {
            Dictionary<string, T> resultDictionary = new Dictionary<string, T>();
            T result = default(T);
            var taskList = new List<Task<KeyValuePair<string, T>>>();
            using (SqlConnection connection = new SqlConnection(_conStr))
            {
                await connection.OpenAsync();

                foreach (var current in procList)
                    taskList.Add(ExecuteDataReader(connection, current.Value, current.Key, output));

                foreach (var task in await Task.WhenAll(taskList))
                    resultDictionary.Add(task.Key, task.Value);

            }
            return resultDictionary;
        }

        private async Task<KeyValuePair<string, T>> ExecuteDataReader<T>(SqlConnection connection, List<SqlParameter> paramList, string procName, Func<SqlDataReader, T> output)
        {
            SqlDataReader reader = null;
            KeyValuePair<string, T> kvp;
            if (connection.State != ConnectionState.Open)
                connection.Open();

            using (SqlCommand command = new SqlCommand(procName, connection))
            {
                command.CommandType = CommandType.StoredProcedure;

                if (paramList != null)
                {
                    foreach (var param in paramList)
                        command.Parameters.Add(param);
                }
                Stopwatch watch = new Stopwatch();
                watch.Start();
                reader = await command.ExecuteReaderAsync();

                watch.Stop();
                AppLogger.LogTimer(watch);
                //_logger.Info(string.Format("{0} took {1} milliseconds", procName, watch.ElapsedMilliseconds));
                kvp = new KeyValuePair<string, T>(procName, output(reader));
            }

            return kvp;
        }
    }
}