using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MimeKit;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AudioController
    {
        [HttpGet("{name}")]
        public async Task<IActionResult> Transform(string name)
        {

            string filePath = Path.GetFullPath($"asm/{name}");
            
            return new PhysicalFileResult(filePath, MimeTypes.GetMimeType(filePath));
        }
        [HttpPost("{reverb}")]
        public async Task<string> Transform([FromForm] IFormFile wav, bool reverb)
        {
            string outputname = reverb ? "newsongdereverb.wav" : "newsongreverb.wav" ;
            if(!File.Exists(Path.GetFullPath($"asm/{outputname}")))
            {
                string filename = reverb ? "asm/resong.wav" : "asm/desong.wav";
                string exec = reverb ? "reverb.sh" : "dereverb.sh";

                var command = "sh";
                var myBatchFile = exec;
                var argss = exec;

                var processInfo = new ProcessStartInfo();
                processInfo.WorkingDirectory = "asm/";
                processInfo.UseShellExecute = false;
                processInfo.FileName = command;   // 'sh' for bash 
                processInfo.Arguments = argss;    // The Script name 

                System.Console.WriteLine("Converting Audio File...");
                await Task.Run(() =>
                {
                    var process = Process.Start(processInfo);   // Start that process.
                
                    process.WaitForExit();
                });
                System.Console.WriteLine("Done!");
            }
            else System.Console.WriteLine("File already exists.");


            
            return $"http://localhost:5000/api/Audio/{outputname}";
        }
    }
}
