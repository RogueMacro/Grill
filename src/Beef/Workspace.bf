using System;
using System.Collections;

namespace Grill.Beef
{
	public class Workspace
	{
		public int FileVersion { get; set; }
		public Dictionary<String, Object> Projects { get; set; }
	}
}
