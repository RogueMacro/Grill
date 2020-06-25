namespace System.Collections
{
	extension List<T> where T : delete
	{
		public bool DeleteAndRemove(T item)
		{
			int index = IndexOf(item);
			if (index >= 0)
			{
				delete this[index];
				RemoveAt(index);
				return true;
			}

			return false;
		}
	}
}
