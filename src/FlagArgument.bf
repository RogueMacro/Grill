using System;

namespace bpm
{
	public class FlagArgument : CommandArgument
	{
		public this(String name)
		{
			Name = name;
			Value = true;
		}
	}
}
