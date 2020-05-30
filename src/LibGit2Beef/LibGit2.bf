using System;

namespace bpm.LibGit2Beef
{
	static class LibGit2
	{
		[CLink]
		public static extern void git_clone(void* git_repository);
	}

	[CRepr]
	struct git_repository
	{

	}
}
