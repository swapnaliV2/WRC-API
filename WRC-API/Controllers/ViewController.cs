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
            //_logger.Info(string.Format("Entire Call for {0} took {1}", form, watch.ElapsedMilliseconds));
            //return data;
        }


        [Route("ExecuteDS/{commanName}"), HttpPost]
        public async Task<string> ExecuteDataset([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            //var Result1 = await _renderService.ExecuteDataSet(commanName, paramSet);
            var Result =JsonConvert.SerializeObject (await _renderService.ExecuteDataSet(commanName, paramSet),Formatting.None );
            var minfyJson = Regex.Replace(Result, "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+", "$1");
            //GZipStream com = new GZipStream(Result1, CompressionMode.Compress);
            watch.Stop();
            //_logger.Info(string.Format("Entire Call for {0} took {1}", form, watch.ElapsedMilliseconds));
            return minfyJson;
        }

        [Route("UpdateNQ/{commanName}"), HttpPost]
        public void UpdateNonQuery([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            _renderService.UpdateNonQuery(commanName, paramSet);
            watch.Stop();
        }

        [Route("DeleteNQ/{commanName}"), HttpPost]
        public void DeleteNonQuery([FromUri] string commanName, [FromBody]Dictionary<string, string> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            _renderService.DeleteNonQuery(commanName, paramSet);
            watch.Stop();
        }

        //[Route("for/{formname}"), HttpPost]
        //public async Task StartUp([FromUri] string form, [FromBody]Dictionary<string, object> paramSet)
        //{
        //    Stopwatch watch = new Stopwatch();
        //    watch.Start();
        //    await _renderService.Fetch(form, paramSet);

        //    watch.Stop();
        //    //_logger.Info(string.Format("Entire Call for {0} took {1}", form, watch.ElapsedMilliseconds));
        //    //return data;
        //}
    }
}
