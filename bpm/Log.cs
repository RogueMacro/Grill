using System;

namespace bpm
{
    public static class Log
    {
        private static void _Log(string text, ConsoleColor color = ConsoleColor.White)
        {
            var origin = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = origin;
        }

        public static void Success(string text) => _Log(text, ConsoleColor.Green);
        public static void Info(string text) => _Log(text, ConsoleColor.Cyan);
        public static void Warning(string text) => _Log("[Warning] " + text, ConsoleColor.Yellow);
        public static void Error(string text) => _Log("[Error] " + text, ConsoleColor.Red);
        public static void Fatal(string text, ExitCode exitCode)
        {
            _Log("[Error] " + text, ConsoleColor.Red);
            Environment.Exit((int) exitCode);
        }
    }
}
