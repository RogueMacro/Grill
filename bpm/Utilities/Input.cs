using System;

namespace bpm.Utilities
{
    public static class Input
    {
        public static bool GetChoice(string prompt = "")
        {
        AskForChar:
            Console.Write(prompt + " [y/n] ");
            var chr = Console.ReadKey().KeyChar;
            Console.WriteLine();
            if (chr == 'y')
            {
                return true;
            }
            else if (chr != 'n')
            {
                goto AskForChar;
            }

            return false;
        }
    }
}
