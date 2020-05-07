namespace bpm.Commands
{
    public interface ICommand
    {
        public void Execute(string[] args);
    }
}