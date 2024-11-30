package br.com.sigas.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.Categorias;

import java.util.List;

@Repository
public interface CategoriasRepository extends JpaRepository<Categorias, Long> {

    @Query("SELECT c FROM Categorias c WHERE c.id_categoria = :id")
    Categorias buscarPorId(@Param("id") Long id);

    @Query("SELECT c FROM Categorias c WHERE LOWER(c.nome_categoria) LIKE LOWER(CONCAT('%', :nome, '%'))")
    List<Categorias> buscarPorNome(@Param("nome") String nome);

    @Procedure(procedureName = "dbo.inserir_categoria")
    void inserirCategoria(@Param("nome_categoria") String nomeCategoria);

    @Procedure(procedureName = "atualizar_categoria")
    void atualizarCategoria(
            @Param("id_categoria") Long idCategoria,
            @Param("nome_categoria") String nomeCategoria);

    @Procedure(procedureName = "deletar_categoria")
    void deletarCategoria(@Param("id_categoria") Long idCategoria);
}
