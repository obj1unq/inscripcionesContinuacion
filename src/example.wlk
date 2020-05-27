class Carrera {
	const property materias
	
	method pertenece(materia) {
		return materias.contains(materia)
	}
}

class Inscripcion{
	const property estudiante
	var property firme
	method usaCupo() {return firme}
	method desinscribir(materia) {
		materia.removerInscripcion(self)
		if(self.usaCupo()) {
			materia.desencolar()
		}
	}
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
	
	method inscribir(_estudiante) {
		self.validarNoInscripto(_estudiante)
	    inscripciones.add(new Inscripcion(estudiante=_estudiante, firme = self.cupoUsado() < cupo))
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
		inscripciones.find({inscripcion => inscripcion.estudiante() == alumno}).desinscribir(self)
	}
	method removerInscripcion(inscripcion) {
		inscripciones.remove(inscripcion)
	}
	
	method desencolar() {
		const enEspera = inscripciones.findOrDefault({inscripcion => not inscripcion.usaCupo()}, null)
		if(enEspera != null) {
			enEspera.firme(true)
		}
	}
	
}


class Estudiante {
	
	const property carreras = #{}
	const property inscriptas = #{} 
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

   //por ahora retorna true si está firme o en espera	
	method inscripta(_materia) {
		return inscriptas.contains(_materia)
	}
	
	method todasLasMaterias() {
		return carreras.map({carrera => carrera.materias()}).flatten()
	}
	
	method puedeInscribirse(_materia) {
		return self.esDeUnaCarreraQueCursa(_materia) and 
				not self.aprobada(_materia) and 
				not self.inscripta(_materia) and
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
		inscriptas.add(materia)
	}

	method desinscribir(materia) {
		materia.desinscribir(self)
		inscriptas.remove(materia)
	}
	
	method inscripcionesFirmes() {
		return inscriptas.filter({materia => materia.esInscriptFirme(self)})
	}
	
	method inscripcionesEnEspera() {
		return inscriptas.filter({materia => not materia.esInscriptFirme(self)})
	}
	
}
