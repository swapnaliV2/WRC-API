using System;
using System.Diagnostics;
using System.IO;

namespace WRC_API.HelperClass
{
    public class AppLogger
    {
        static string _FileName = "D:/WRCLogger.txt";
        static string _FileNameAPI = "D:/WRCLoggerAPI.txt";
        public static void LogError(Exception ex)
        {
            try
            {
                string logMessageToLog = string.Concat(">> Error occured : ", ex.Message, Environment.NewLine, ex.StackTrace, Environment.NewLine);
                File.AppendAllText(_FileName, logMessageToLog);
            }
            catch { }
        }

        public static void LogTimer(Stopwatch watch)
        {
            try
            {
                string logMessageToLog = string.Concat("Time Taken : ", watch.ElapsedMilliseconds, " MilliSeconds", Environment.NewLine);
                File.AppendAllText(_FileName, logMessageToLog);
            }
            catch { }
        }
        
        public static void LogTimerAPI(Stopwatch watch)
        {
            try
            {
                string logMessageToLog = string.Concat("Time Taken : ", watch.ElapsedMilliseconds, " MilliSeconds", Environment.NewLine);
                File.AppendAllText(_FileNameAPI, logMessageToLog);
            }
            catch { }
        }
    }
}