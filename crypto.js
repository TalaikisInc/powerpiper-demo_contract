import { randomBytes, createCipher, createDecipher } from 'crypto'
const algorithm = 'aes-256-ctr'

export function generateKey () {
  const pass = randomBytes(128)
  const passBase64 = pass.toString('base64')
  return passBase64
}

export function encrypt (text, password) {
  const cipher = createCipher(algorithm, password)
  let crypted = cipher.update(text, 'utf8', 'hex')
  crypted += cipher.final('hex')
  return crypted
}

export function decrypt (text, password) {
  const decipher = createDecipher(algorithm, password)
  let dec = decipher.update(text, 'hex', 'utf8')
  dec += decipher.final('utf8')
  return dec
}
