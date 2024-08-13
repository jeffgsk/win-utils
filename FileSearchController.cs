using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using System.IO;
using System.Linq;

namespace MvcFileSearchApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FileSearchController : ControllerBase
    {

        public class FileContentRequest
        {
            public string RootPath { get; set; } = string.Empty;
            public string RelativeFilePath { get; set; } = string.Empty;
        }
        public class SearchRequest
        {
            public string Path { get; set; } = string.Empty;
            public string[] Extensions { get; set; } = Array.Empty<string>();
        }

        [HttpPost("search")]
        public IActionResult SearchFiles([FromBody] SearchRequest request)
        {
            if (string.IsNullOrEmpty(request.Path) || !Directory.Exists(request.Path))
            {
                return BadRequest("Invalid or missing path parameter.");
            }

            if (request.Extensions == null || request.Extensions.Length == 0)
            {
                return BadRequest("Extensions array cannot be null or empty.");
            }

            var allfiles = Directory.GetFiles(request.Path, "*.*", SearchOption.AllDirectories);

            var files = allfiles
                .Where(file => request.Extensions.Contains(Path.GetExtension(file)))
                .Select(file => new
                {
                    RelativePath = Path.GetRelativePath(request.Path, file)
                })
                .ToList();

            return Ok(files);
        }

        [HttpPost("file-content")]
        public IActionResult GetFileContent([FromBody] FileContentRequest request)
        {
            if (string.IsNullOrEmpty(request.RootPath) || !Directory.Exists(request.RootPath))
            {
                return BadRequest("Invalid or missing rootPath parameter.");
            }

            var fullPath = Path.Combine(request.RootPath, request.RelativeFilePath);

            if (!System.IO.File.Exists(fullPath))
            {
                return NotFound("File not found.");
            }

            var fileContent = System.IO.File.ReadAllText(fullPath);

            return Ok(new { Content = fileContent });
        }
    
    }
}
