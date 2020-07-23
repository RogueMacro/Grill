using System;
using System.Collections;

namespace Grill
{
	[Reflect]
	public class WorkspaceFile
	{
		public Dictionary<String, Object> Projects ~ DeleteDictionaryAndKeysAndItems!(_);
		public Dictionary<String, Object> Workspace ~ DeleteDictionaryAndKeysAndItems!(_);
	}
}
