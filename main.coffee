fs = require 'fs'
os = require 'os'
bytes = require 'bytes'
cors = require 'cors'
express = require 'express'
{ fromBuffer } = require 'file-type'
multer = require 'multer'

limitSize = '5000mb'
tmpFolder = os.tmpdir()

app = express()
app.set 'json spaces', 4

app.use cors()
# limit upload file
app.use express.json limit: limitSize
app.use express.urlencoded extended: true, limit: limitSize

# multer configuration
upload = multer({ dest: tmpFolder })

# logger
app.use (req, res, next) ->
	time = new Date().toLocaleString 'id', timeZone: 'Asia/Jakarta'
	console.log "[#{time}] #{req.method}: #{req.url}"
	next()

# allow user to access file in tmpFolder
app.use '/file', express.static tmpFolder

app.all '/', (_, res) -> res.send 'POST /upload'

app.post '/upload', upload.single('file'), (req, res) ->
	if not req.file
		res.json message: 'No file uploaded'

	fileBuffer = fs.readFileSync req.file.path
	ftype = await fromBuffer fileBuffer
	if not ftype then ftype = mime: 'file', ext: 'bin'
	
	randomName = Math.random().toString(36).slice(2)
	fileName = "#{ftype.mime.split('/')[0]}-#{randomName}.#{ftype.ext}"
	await fs.promises.rename req.file.path, "#{tmpFolder}/#{fileName}"
	res.json
		name: fileName,
		size:
			bytes: fileBuffer.length,
			readable: bytes fileBuffer.length, unitSeparator: ' '
		,
		type: ftype,
		url: "https://#{process.env.SPACE_HOST}/file/#{fileName}"

app.listen 7860, () -> console.log 'App running on port', 7860
