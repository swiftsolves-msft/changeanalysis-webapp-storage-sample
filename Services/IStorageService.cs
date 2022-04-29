using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace WebAppStorageAlbum.Services
{
    public interface IStorageService
    {
        Task <IEnumerable<string>> GetImagesList();
        Task AddImageAsync(Stream stream, string fileName);
    }
}
