object listUtils {
	
	
	method indexOf(list, element) {
		if(not list.contains(element)) {
			self.error("element " + element + "is not present on list" + element)
		}
		return self.indexOf(list, element, 0)	
	}
	
	method indexOf(list, element, counter) {
		if (list.get(counter) == element) {
			return counter
		}
		else {
			return self.indexOf(list, element, counter + 1)
		}
	}
}

class Carrera {
	const property materias
	
	method pertenece(materia) {
		return materias.contains(materia)
	}
}

class Cursada {
	const property materia
	const property nota
}

class Materia {
	const requisitos = #{}
	const cupo = 20
	
	const inscriptos = []
	
	method cumpleRequisitos(estudiante) {
		return requisitos.all({requisito => estudiante.aprobada(requisito)})
	}
		
	method cupoUsado() {
		return return inscriptos.size().min(cupo)
	}
		
	method inscribir(_estudiante) {
		self.validarNoInscripto(_estudiante)
	    inscriptos.add(_estudiante)
	}
	
	
	method validarNoInscripto(estudiante) {
		if(self.inscripto(estudiante)) {
			self.error("El estudiante ya esta inscripto")
		}
	}
	
	method validarInscripto(estudiante) {
		if(not self.inscripto(estudiante)) {
			self.error("El estudiante no esta inscripto")
		}
	}
	
	method desinscribir(alumno) {
		self.validarInscripto(alumno)
		inscriptos.remove(alumno)
	}
	
    method inscripto(_estudiante) {
		return inscriptos.contains(_estudiante)
	}
	
	method usaCupo(_estudiante) {
		return listUtils.indexOf(inscriptos, _estudiante) < cupo
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
