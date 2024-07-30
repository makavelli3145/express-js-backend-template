import axios, { AxiosRequestConfig } from 'axios';

export default async function sendApiRequest(config: AxiosRequestConfig): Promise<object | NodeJS.ErrnoException> {
  return await axios
    .request(config)
    .then(result => result.data)
    .catch(error => error);
}
