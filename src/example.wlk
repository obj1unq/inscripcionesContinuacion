class Carrera {
	const property materias
	
	method pertenece(materia) {
		return materias.contains(materia)
	}
}

class Inscripcion{
	const property estudiante
	const property materia
	
	method usaCupo() 
	method desinscribir() {
		materia.removerInscripcion(self)
	}
}
class InscripcionFirme inherits Inscripcion{
	
	override method usaCupo() { return true }
	override method desinscribir() {
		super()
		if(materia.hayInscripcionEnEspera()) {
			const proximo = materia.proximoEnEspera()
			materia.removerInscripcion(proximo)
			materia.agregarInscripcion(new InscripcionFirme(materia=proximo.materia(), estudiante = proximo.estudiante()))
		}
	}	
}

class InscripcionEnEspera inherits Inscripcion{
	override method usaCupo() { return false }
}


class Cursada {
	const property materia
	const property nota
}

class Materia {
	const requisitos = #{}
	const cupo = 20
	
	const inscripciones = []
	
	method cumpleRequisitos(estudiante) {
		return requisitos.all({requisito => estudiante.aprobada(requisito)})
	}
		
	method cupoUsado() {
		return inscripciones.count({inscripcion => inscripcion.usaCupo()})
	}
	
	method agregarInscripcion(_inscripcion) {
	    inscripciones.add(_inscripcion)
	}
	
	method inscribir(_estudiante) {
		self.validarNoInscripto(_estudiante)
		
		const inscripcion = if(self.cupoUsado() < cupo)  {
			new InscripcionFirme(estudiante=_estudiante, materia=self) 
		}
		else {
			new InscripcionEnEspera(estudiante=_estudiante, materia=self)	
		}
		 
	    self.agregarInscripcion(inscripcion)
	}
	
	method tieneInscripcion(estudiante) {
		return inscripciones.any({inscripcion => inscripcion.estudiante() == estudiante})
	}
	
	method validarNoInscripto(estudiante) {
		if(self.tieneInscripcion(estudiante)) {
			self.error("El estudiante ya esta inscripto")
		}
	}
	
	method validarInscripto(estudiante) {
		if(not self.tieneInscripcion(estudiante)) {
			self.error("El estudiante no esta inscripto")
		}
	}
	
	method desinscribir(alumno) {
		self.validarInscripto(alumno)
		const inscripcion = inscripciones.find({inscripcion => inscripcion.estudiante() == alumno})
		inscripcion.desinscribir()
	}
	
	method removerInscripcion(inscripcion) {
		inscripciones.remove(inscripcion)
	}
	

    method inscripto(_estudiante) {
		return inscripciones.any({inscripcion => inscripcion.estudiante() == _estudiante})
	}
	
	method usaCupo(_estudiante) {
		return inscripciones.any({inscripcion => inscripcion.estudiante() == _estudiante and inscripcion.usaCupo()})
	}
	
	method hayInscripcionEnEspera() {
		return inscripciones.any({inscripcion=> not inscripcion.usaCupo()})
	}

	method proximoEnEspera() {
		return inscripciones.find({inscripcion=> not inscripcion.usaCupo()})
	}
	
}


class Estudiante {
	
	const property carreras = #{}
	const cursadas = #{}
	
	method aprobar(_materia, _nota){
		self.validarNoAprobada(_materia)
		cursadas.add(new Cursada(materia=_materia, nota=_nota))
	}
	
	method validarNoAprobada(_materia) {
		if(self.aprobada(_materia)) {
			self.error("Materia" + _materia + " ya esta aprobada")
		}
	}
	
	method cantidadMateriasAprobadas() {
		return cursadas.size()
	}

	method promedio() {
		return cursadas.sum({ cursada => cursada.nota()}) / self.cantidadMateriasAprobadas()
	}
	
	method aprobada(_materia) {
		return cursadas.any({cursada => cursada.materia() == _materia})
	}
	
	method materiasInscriptas() {
		return self.todasLasMaterias().filter({materia=> materia.inscripto(self)})
	}

	
	method todasLasMaterias() {
		return carreras.map({carrera => carrera.materias()}).flatten()
	}
	
	method puedeInscribirse(_materia) {
		return self.esDeUnaCarreraQueCursa(_materia) and 
				not self.aprobada(_materia) and 
				not _materia.inscripto(self) and
				_materia.cumpleRequisitos(self)
	}
	
	method esDeUnaCarreraQueCursa(_materia) {
		return carreras.any({carrera=> carrera.pertenece(_materia)})
	}
	
	method validarInscripcion(_materia) {
		if(! self.puedeInscribirse(_materia)) {
			self.error("puedeInscribirse")
		}
	}
	
	method inscribir(materia) {
		self.validarInscripcion(materia)
		materia.inscribir(self)
	}

	method desinscribir(materia) {
		materia.desinscribir(self)
	}
	
	method materiasInscriptasFirmes() {
		return self.materiasInscriptas().filter({materia => materia.usaCupo(self)})
	}
	
	method materiasInscriptasEnEspera() {
		return self.materiasInscriptas().filter({materia => not materia.usaCupo(self)})
	}
	
	method inscriptaFirme(_materia) {
		return self.materiasInscriptasFirmes().contains(_materia)
	}

	method inscriptaEnEspera(_materia) {
		return self.materiasInscriptasEnEspera().contains(_materia)
	}
	
}
