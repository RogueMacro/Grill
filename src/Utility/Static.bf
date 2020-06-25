using System;

namespace Grill.Utility
{
	static
	{
		public static mixin DeleteSpan<T>(Span<T> span) where T : delete
		{
			delete span.Ptr;
		}

		public static mixin DeleteContainerAndInterfaces(var container)
		{
			for (var item in container)
				delete (Object) item;
		}
	}
}
