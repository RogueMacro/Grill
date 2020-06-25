using Grill;
using Grill.Utility;

namespace System
{
	extension Console
	{
		public static void EmptyLine(int length)
		{
			Console.Write('\r');
			for (int i = 0; i < length; ++i)
				Console.Write(' ');
			Console.Write('\r');
		}

		public static char8 ReadKey()
		{
			return Cpp.getch();
		}
	}
}
