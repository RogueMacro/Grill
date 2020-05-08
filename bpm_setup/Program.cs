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
                else
                {
                    bpmBinPath = "/usr/bin";
                }

                foreach (var resource in Assembly.GetExecutingAssembly().GetManifestResourceNames())
                {
                    string newName = resource.Remove(0, 20);
                    if (newName.Contains("bpm"))
                        newName = platform == PlatformID.Win32NT ? "bpm.exe" : "bpm";
                    WriteResource(resource, newName, Path.Combine(bpmBinPath, resource));
                }

                PrintColor("Installed successfully", ConsoleColor.Green);

                Console.WriteLine("Press any key to exit");
                Console.ReadKey();
            }
            catch (UnauthorizedAccessException e)
            {
                PrintColor($"{e.Message} Run again as administrator.", ConsoleColor.Red);
                Console.Read();
            }
            catch (Exception e)
            {
                PrintColor(e.Message, ConsoleColor.Red);
                Console.Read();
            }
        }

        static void WriteResource(string resource, string newName, string path)
        {
            var output = File.Open(path, FileMode.OpenOrCreate);
            var input = Assembly.GetExecutingAssembly().GetManifestResourceStream(resource);
            if (input == null)
            {
                PrintColor("Could not get executable resource", ConsoleColor.Red);
                Console.Read();
                throw new Exception();
            }
            input.CopyTo(output);
            input.Close();
            output.Close();
            string newPath = Path.Combine(Path.GetDirectoryName(path), newName);

            if (File.Exists(newPath))
                File.Delete(newPath);

            File.Move(path, newPath);
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
