terraform {
  backend "s3" {
    region   = "ru-central1"
    bucket   = "reddit-app-terraform-backend"
    endpoint = "storage.yandexcloud.net"
    key      = "stage.tfstate"
    # Фикс ошибки: Error: Invalid AWS Region: ru-central1
    skip_region_validation = true
    # Фикс ошибки: Error: error using credentials to get account ID: error calling sts:GetCallerIdentity: RequestError: send request failed caused by: Post https://sts.ru-central1.amazonaws.com/: dial tcp: lookup sts.ru-central1.amazonaws.com on 192.168.42.129:53: no such host
    skip_credentials_validation = true
  }
}
