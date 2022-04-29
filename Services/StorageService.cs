using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Azure;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace WebAppStorageAlbum.Services
{
    public class StorageService : IStorageService
    {
        private static bool ResourcesInitialized { get; set; } = false;

        private readonly string _storageConnectionString;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _containerName;
        private static BlobContainerClient _containerClient;

        private readonly ILogger _logger;


        public StorageService(IConfiguration config, ILogger<StorageService> logger)
        {
            _logger = logger;

            _storageConnectionString = config["AzureStorageConnection"];
            _blobServiceClient = new BlobServiceClient(_storageConnectionString);
            _containerName = "images";

        }

        public async Task AddImageAsync(Stream stream, string fileName)
        {
            await initializeAccount();

            BlobClient blobClient = _containerClient.GetBlobClient(fileName);

            await blobClient.UploadAsync(stream);

        }

        public async Task<IEnumerable<string>> GetImagesList()
        {
            List<string> images = new List<string>();

            await initializeAccount();

            Pageable<BlobItem> blobList = _containerClient.GetBlobs();

            foreach (BlobItem blobItem in blobList)
            {
                images.Add(_containerClient.Uri + "/"+ blobItem.Name);

            }

            return images;
        }

        private async Task initializeAccount()
        {
            if (!ResourcesInitialized)
            {
                try
                {
                    _containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                    await _containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message);
                }
            }

            ResourcesInitialized = true;
        }

    }
}
