namespace Grill.Utility
{
	public static
	{
		public static mixin Delete(var object)
		{
			if (object != null)
				delete object;
		}
	}
}
