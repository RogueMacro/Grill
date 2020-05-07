using bpm.Utilities;
using System;
using System.IO;
using System.Linq;
using System.Runtime.ExceptionServices;

namespace bpm.Logging
{
    public static class Log
    {
        public static ExitCode LastExitCode = ExitCode.SUCCESS;

        public const uint MaxLogFiles = 10;
        public static StreamWriter LogFile { get; set; }

        private static bool mTracedException = false;

        private static void _Log(string text, ConsoleColor color = ConsoleColor.White, bool trace = true)
        {
            var origin = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = origin;

            if (trace)
                Trace(text);
        }

        public static void Trace(string message, bool tracingException = false)
        {
            if (mTracedException)
            {
                mTracedException = false;
                return;
            }

            if (!tracingException)
            {
                mTracedException = false;
                LogFile.WriteLine($"[{DateTime.Now.Ticks}] {message}");
            }
            else
            {
                mTracedException = true;
            }
        }

        public static void CatchExceptionEvent(object source, FirstChanceExceptionEventArgs args) => Trace($"{args.Exception.GetType()}: {args.Exception.Message}", true);

        public static void CatchUnhandledExceptionEvent(object source, UnhandledExceptionEventArgs args) => Trace($"{args.ExceptionObject.GetType()}: {((Exception) args.ExceptionObject).Message}", true);

        public static void Info(string text) => _Log(text);

        public static void Usage(string text) => _Log($"Usage: {text}", ConsoleColor.White, false);

        public static void Success(string text) => _Log(text, ConsoleColor.Green);

        public static void Warning(string text) => _Log(text, ConsoleColor.Yellow);

        public static void Error(string text) => _Log(text, ConsoleColor.Red);

        public static void Fatal(string text, ExitCode exitCode)
        {
            Error(text);
            LastExitCode = exitCode;
        }

        public static void Init()
        {
            LogFile = new StreamWriter(Path.Combine(BpmPath.LogFolder, DateTime.Now.ToString("dd-yyyy_h-mm-ss") + ".log")) { AutoFlush = true };

            var files = new DirectoryInfo(BpmPath.LogFolder)
                    .GetFiles()
                    .OrderBy(f => f.LastWriteTime)
                    .ToList();

            for (int i = 0; i < files.Count - MaxLogFiles; i++)
                File.Delete(files[i].FullName);
        }
    }
}