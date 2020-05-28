class Materia {
	const property requisitos = #{}
	
	method puedeCursar(_estudiante) {
		return requisitos.all({requisito => _estudiante.aprobada(requisito)})
	}
}

class Cursada {
	const property materia
	const property nota
}

class Carrera {
	const property materias
}

class Estudiante {
	
	const cursadasAprobadas = #{}
	const property carreras
	const property materiasInscriptas = #{}
	
	
	method validarNoAprobada(_materia) {
		if(self.aprobada(_materia)) {
			self.error("la materia " + _materia + " ya está aprobada")
		}
	}
	
	method aprobar(_materia, _nota) {
		self.validarNoAprobada(_materia)
		cursadasAprobadas.add(new Cursada(materia=_materia, nota=_nota))	
	}
	
	method aprobada(materia) {
		return cursadasAprobadas.any({cursada => cursada.materia() == materia})
	}
	
	method cantidadMateriasAprobadas() {
		return cursadasAprobadas.size()	
	}
	
	method promedio() {
		return  self.sumatoriaNotas() / self.cantidadMateriasAprobadas()
	}
	
	method sumatoriaNotas() {
		return cursadasAprobadas.sum({cursada => cursada.nota()})
	}
	
	method todasLasMaterias() {
		return carreras.map({carrera => carrera.materias()}).flatten()
	}
	
	method validarInscripcion(_materia) {
		if(not self.puedeInscribirse(_materia)) {
			self.error("no se puede inscribir a " + _materia )
		}
	}
	
	method inscribir(_materia) {
		self.validarInscripcion(_materia)
		materiasInscriptas.add(_materia)	
	}
	
	method estaEnAlgunaCarrera(_materia) {
		return self.todasLasMaterias().contains(_materia)
	}
	
	method puedeInscribirse(_materia) {
		return self.estaEnAlgunaCarrera(_materia) and
		       not self.aprobada(_materia) and
		       not self.inscripta(_materia) and
		       _materia.puedeCursar(self)		       
	}
	
	method inscripta(_materia) {
		return materiasInscriptas.contains(_materia)
	}
	
	
}