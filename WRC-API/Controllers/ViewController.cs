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
using Newtonsoft.Json.Linq;
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
            //This will be helping if data send through request will be decompressed.
            CommonClass.DeCompressData();

            _renderService.RaiseDBRequestAndForget(commanName, paramSet);
        }

        [Route("ExecuteDS/{commanName}"), HttpPost]
        public async Task<object> ExecuteDataset([FromUri] string commanName, [FromBody]Dictionary<string, object> paramSet)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            DataSet Result = await _renderService.ExecuteDataSet(commanName, paramSet);
            //           var compStr = CommonClass.MiniFyAndCompressData(JsonResult);

            watch.Stop();

            AppLogger.LogTimerAPI(watch);

            return Result;
        }

        [Route("RenderView/{siteId}/{viewId}"), HttpPost]
        public async Task<object> RenderViewFromSite([FromUri] int siteId, [FromUri] int viewId, [FromBody]Dictionary<string, object> paramSet)
        {
            Request.Headers.Add("Accept-Encoding", "gzip");

            Stopwatch watch = new Stopwatch();
            watch.Start();
            object result = await _renderService.RenderViewData(siteId, viewId, paramSet);
            watch.Stop();

            AppLogger.LogTimerAPI(watch);

            return result;
        }
    }
}
