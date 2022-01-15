# khaledez.net

# Infrastructure
## After cloning
* update files to match your settings
* run:
```sh
$ cd terraform/infrastructre 
$ terraform init && terraform apply
```

# Development

```sh
$ npm install
$ npm run dev
```

## End-To-End Testing

You can build a full production-like environment, given you have infrastructure setup

Refer the script `please`.

* Create test environment
```sh
$ ./please init
$ ./please sync
```
* Build app for production
```sh
$ ./please build
```
* Update AWS resources
```sh
$ ./please sync
```
* Deploy app to the environment
```sh
$ ./please deploy
```
* After finishing development
```sh
$ ./please destroy
```