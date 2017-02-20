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
        public void ExecuteNonQuery([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            _renderService.ExecuteNonQuery(commanName, paramSet);
            watch.Stop();
            //return data;
        }

        [Route("ExecuteDS/{commanName}"), HttpPost]
        public async Task<string> ExecuteDataset([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();            
            var Result =JsonConvert.SerializeObject (await _renderService.ExecuteDataSet(commanName, paramSet),Formatting.None );
            watch.Stop();
            var minifyJson = Regex.Replace(Result, "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+", "$1");
            var compStr =GZipCompressDecompress.Zip(minifyJson);
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
