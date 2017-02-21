using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using WRC_API.Services;
using Newtonsoft.Json;
using System.IO.Compression;
using System.Text.RegularExpressions;
using WRC_API.HelperClass;
using System.Data;
namespace WRC_API.Controllers
{
    [RoutePrefix("View")]
    public class ViewController : ApiController
    {
        private FormRenderService _renderService;
        
        public ViewController() : this(new FormRenderService()) { }

        public ViewController(FormRenderService service)
        {
            _renderService = service;
        }

        [Route("Execute/{commanName}"), HttpPost]
        public void ExecuteNonQuery([FromUri] string commanName, [FromBody] Dictionary<string, object> paramSet)
        {            
            Stopwatch watch = new Stopwatch();

            //TODO: Convert compress data into original format
            //Dictionary<string, object> dcomstr;
            //var Result = JsonConvert.SerializeObject (paramSet.ToString());
            //var comStr = GZipCompressDecompress.Zip(Result.ToString ());
            //var decomStr1 = GZipCompressDecompress.UnZip(comStr); 

            watch.Start();
            _renderService.ExecuteNonQuery(commanName, paramSet);
            watch.Stop();
            //return data;
        }

        [Route("ExecuteDS/{commanName}"), HttpPost]
        public async Task<string> ExecuteDataset([FromUri] string commanName, [FromBody]Dictionary<string, object> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            DataSet  Result = await _renderService.ExecuteDataSet(commanName, paramSet);
            var JsonResult = JsonConvert.SerializeObject(Result, Formatting.None);
            watch.Stop();
            var minifyJson = Regex.Replace(JsonResult, "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+", "$1");
            var compStr = GZipCompressDecompress.Zip(minifyJson);

            /* To decompress data and get into its original format(here in DataSet)
            var decomStr = GZipCompressDecompress.UnZip (compStr);
            var ds = JsonConvert.DeserializeObject<DataSet>(decomStr);
           */
            return compStr;
        }

        //[Route("UpdateNQ/{commanName}"), HttpPost]
        //public void UpdateNonQuery([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        //{
        //    Stopwatch watch = new Stopwatch();
        //    watch.Start();
        //    _renderService.UpdateNonQuery(commanName, paramSet);
        //    watch.Stop();
        //}

        //[Route("DeleteNQ/{commanName}"), HttpPost]
        //public void DeleteNonQuery([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        //{
        //    Stopwatch watch = new Stopwatch();
        //    watch.Start();
        //    _renderService.DeleteNonQuery(commanName, paramSet);
        //    watch.Stop();
        //}      
    }
}
