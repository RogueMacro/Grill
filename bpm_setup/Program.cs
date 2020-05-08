using System;
using System.IO;
using System.Linq;
using System.Reflection;

namespace bpm_setup
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                var platform = Environment.OSVersion.Platform;
                string executable = Assembly.GetExecutingAssembly().GetManifestResourceNames().Single();
                string bpmBinPath;
                if (platform == PlatformID.Win32NT)
                {
                    bpmBinPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "bpm", "bin");
                    if (!Directory.Exists(bpmBinPath))
                        Directory.CreateDirectory(bpmBinPath);

                    bool addToPath;
                AskForPath:
                    Console.Write("Add to path? [y/n] ");
                    char choice = Console.ReadKey().KeyChar;
                    Console.WriteLine();
                    if (choice == 'y')
                        addToPath = true;
                    else if (choice == 'n')
                        addToPath = false;
                    else
                        goto AskForPath;

                    if (addToPath)
                    {
                        bool forAllUsers;
                    AskForAllUsers:
                        Console.Write("Install for all users? [y/n] ");
                        choice = Console.ReadKey().KeyChar;
                        Console.WriteLine();
                        if (choice == 'y')
                            forAllUsers = true;
                        else if (choice == 'n')
                            forAllUsers = false;
                        else
                            goto AskForAllUsers;

                        var scope = forAllUsers ? EnvironmentVariableTarget.Machine : EnvironmentVariableTarget.User;
                        string path = Environment.GetEnvironmentVariable("PATH", scope);
                        if (!path.Contains(bpmBinPath))
                        {
                            var newValue = Environment.GetEnvironmentVariable("PATH", scope) + ";" + bpmBinPath;
                            Environment.SetEnvironmentVariable("PATH", newValue, scope);
                        }
                    }
                }
                else
                {
                    bpmBinPath = "/usr/bin";
                }

                WriteResource(executable, Path.Combine(bpmBinPath, executable));

                PrintColor("Installed successfully", ConsoleColor.Green);
            }
            catch (UnauthorizedAccessException)
            {
                PrintColor("Could not install. Run again as administrator.", ConsoleColor.Red);
                Console.Read();
            }
            catch (Exception e)
            {
                PrintColor(e.Message, ConsoleColor.Red);
                Console.Read();
            }
        }

        static void WriteResource(string name, string path)
        {
            var output = File.Open(path, FileMode.OpenOrCreate);
            var input = Assembly.GetExecutingAssembly().GetManifestResourceStream(name);
            if (input == null)
            {
                PrintColor("Could not get executable resource", ConsoleColor.Red);
                Console.Read();
                throw new Exception();
            }
            input.CopyTo(output);
        }

        static bool IsLinux
        {
            get
            {
                int p = (int) Environment.OSVersion.Platform;
                return (p == 4) || (p == 6) || (p == 128);
            }
        }

        static void PrintColor(string text, ConsoleColor color)
        {
            var originalColor = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = originalColor;
        }
    }
}
