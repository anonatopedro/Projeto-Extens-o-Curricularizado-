package br.com.sigas.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.Categorias;
import br.com.sigas.repositories.CategoriasRepository;
import jakarta.persistence.EntityNotFoundException;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CategoriasService {

    @Autowired
    private CategoriasRepository categoriaRepository;

    public Categorias criarCategoria(Categorias categoria) {
        categoriaRepository.inserirCategoria(categoria.getNome_categoria());
        categoria.setIsActive(true);
        categoria.setDataCriacao(LocalDateTime.now());
        categoria.setDataModificacao(LocalDateTime.now());
        return categoria;
    }

    public Categorias buscarPorId(Long id) {
        return categoriaRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Categoria não encontrada."));
    }

    public List<Categorias> buscarPorNome(String nomeCategoria) {
        return categoriaRepository.buscarPorNome(nomeCategoria);
    }

    public void atualizarCategoria(Long id, Categorias categoriaAtualizada) {
        categoriaRepository.atualizarCategoria(id, categoriaAtualizada.getNome_categoria());
    }

    public void deletarCategoria(Long id) {
        categoriaRepository.deletarCategoria(id);
    }
}
