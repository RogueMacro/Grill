using System;

namespace Grill.Commands
{
	public class ValueArgument : CommandArgument
	{
		public this(String name, String value)
		{
			Name = name;
			Value = value;
		}
	}
}
