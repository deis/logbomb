package logbomb

type logWriter interface {
	write() error
}
