namespace bpm.Networking
{
    public static class Url
    {
        public static string Combine(params string[] urls)
        {
            string result = urls[0].Trim('/');
            foreach (var url in urls[1..])
                result = $"{result}/{url.Trim('/')}";

            return result;
        }
    }
}
