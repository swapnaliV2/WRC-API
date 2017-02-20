using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using WRC_API.HelperClass;

namespace WRC_API.Services
{
    public class FormRenderService
    {
        private SqlServer _sqlServer;
        public FormRenderService() : this(new SqlServer()) { }

        public FormRenderService(SqlServer server)
        {
            _sqlServer = server;
        }

        public void ExecuteNonQuery(string commmandName, Dictionary<string, string> Parameters)
        {
            Task.Run(() =>
                ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));
        }

        public async Task<DataTable> ExecuteDataSet(string commmandName, Dictionary<string, string> Parameters)
        {
           return  await ExecuteData(commmandName, Parameters, CommandType.StoredProcedure);
        }

        public void UpdateNonQuery(string commmandName, Dictionary<string, string> Parameters)
        {
            Task.Run(()=>
                 ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));               
        }

        public void DeleteNonQuery(string commmandName, Dictionary<string, string> Parameters)
        {
            Task.Run(() =>
                 ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));
        }

        public void ExecuteDataNQ(string command, Dictionary<string, string> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            innerWatch.Start();

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            try
            {
                if (con.State != ConnectionState.Open)
                    con.Open();

                SqlCommand sqlCommand = new SqlCommand(command, con) { CommandType = commandType };

                foreach (var param in parameters)
                {
                    sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                }

                sqlCommand.ExecuteNonQueryAsync();
                innerWatch.Stop();
                AppLogger.LogTimer(innerWatch);
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

        public async Task<DataTable> ExecuteData(string command, Dictionary<string, string> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            DataTable dtData = new DataTable();
            innerWatch.Start();

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            try
            {
                if (con.State != ConnectionState.Open)
                    con.Open();

                SqlCommand sqlCommand = new SqlCommand(command, con) { CommandType = commandType };

                foreach (var param in parameters)
                {
                    sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                }

               SqlDataReader dr= await sqlCommand.ExecuteReaderAsync();
               dtData.Load(dr);
               innerWatch.Stop();
                AppLogger.LogTimer(innerWatch);
            }
            catch (Exception ex)
            {
                innerWatch.Stop();
                AppLogger.LogError(ex);
               // return 1;
            }
            finally
            {
                if (con.State != ConnectionState.Open)
                    con.Close();
                innerWatch.Stop();
            }
            return dtData;
        }
    }
}