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
	
	const alumnosInscriptos = #{}
	const alumnosEnEspera = []
	
	method cumpleRequisitos(estudiante) {
		return requisitos.all({requisito => estudiante.aprobada(requisito)})
	}
	
	method inscribir(estudiante) {
		if(alumnosInscriptos.size() < cupo) {
			alumnosInscriptos.add(estudiante)
		}
		else {
			alumnosEnEspera.add(estudiante)
		}
	}
	
	method validarInscripto(alumno) {
		return self.esInscriptoFirme(alumno) or alumnosEnEspera.contains(alumno)
	}
	
	method desinscribir(alumno) {
		self.validarInscripto(alumno)
		if(self.esInscriptoFirme(alumno)) {
			alumnosInscriptos.remove(alumno);
			if(alumnosEnEspera.size()>0) {
				const nuevo = alumnosEnEspera.first()
				alumnosEnEspera.remove(nuevo)
				alumnosInscriptos.add(nuevo)
			}
		}
		else {
			alumnosEnEspera.remove(alumno)
		}
	}
	method esInscriptoFirme(estudiante) {
		return alumnosInscriptos.contains(estudiante);
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
	
	method inscripcionesFirmes() {
		return inscriptas.filter({materia => materia.esInscriptFirme(self)})
	}
	
	method inscripcionesEnEspera() {
		return inscriptas.filter({materia => not materia.esInscriptFirme(self)})
	}
	
}
