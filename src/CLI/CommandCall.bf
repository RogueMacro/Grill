using System;
using System.Collections;

namespace Grill.CLI
{
	public class CommandCall
	{
		public String Command = new .() ~ delete _;
		public List<String> Options = new .() ~ DeleteContainerAndItems!(_);
	}
}
