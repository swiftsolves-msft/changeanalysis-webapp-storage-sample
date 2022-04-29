using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using WebAppStorageAlbum.Services;

namespace WebAppStorageAlbum
{
    public class IndexModel : PageModel
    {
        private readonly IStorageService _storageService;

        private readonly ILogger _logger;

        [BindProperty]
        public IFormFile FormFile { get; set; }

        public string Status { get; set; } = "No file uploaded";

        public IEnumerable<string> UploadedImages { get; private set; }


        public IndexModel(IStorageService storageService, ILogger<IndexModel> logger)
        {
            _storageService = storageService ?? throw new ArgumentNullException(nameof(storageService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }
        public async Task OnGetAsync()
        {
           this.UploadedImages = await _storageService.GetImagesList();
        }

        public async Task OnPostUpload()
        {
            await _storageService.AddImageAsync(FormFile.OpenReadStream(), FormFile.FileName);

            this.UploadedImages = await _storageService.GetImagesList();

            Status = FormFile.FileName + " has been successfully uploaded";

        }
    }
}
