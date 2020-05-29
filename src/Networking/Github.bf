using System;

namespace bpm.Networking
{
	enum GithubCloneResult
	{
		Success,
		NoAccess,
		NotFound,
		Error
	}

	public static class Github
	{
		public static GithubCloneResult Clone(StringView url)
		{
			Console.WriteLine("Cloning: {}", url);

			

			return .Error;
		}
	}
}
